// User-level IPC library routines

#include <inc/lib.h>
#include <inc/debug.h>

#if DEBUG_IPC
#define DEBUG_LOG(format,arg...) \
cprintf("[DEBUG][%s]%s <%d>--" format,__FILE__,__FUNCTION__,__LINE__,##arg)
#else
#define DEBUG_LOG(format,arg...)
#endif


// Receive a value via IPC and return it.
// If 'pg' is nonnull, then any page sent by the sender will be mapped at
//	that address.
// If 'from_env_store' is nonnull, then store the IPC sender's envid in
//	*from_env_store.
// If 'perm_store' is nonnull, then store the IPC sender's page permission
//	in *perm_store (this is nonzero iff a page was successfully
//	transferred to 'pg').
// If the system call fails, then store 0 in *fromenv and *perm (if
//	they're nonnull) and return the error.
// Otherwise, return the value sent by the sender
//
// Hint:
//   Use 'thisenv' to discover the value and who sent it.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
	// LAB 4: Your code here.
	int err = 0;
	if(!pg){
		pg = (void*)UTOP;
	}
	DEBUG_LOG("\n");
	err = sys_ipc_recv(pg);
	if(err < 0){
		if(from_env_store){
			*from_env_store = 0;
		}
		if(perm_store){
			*perm_store = 0;
		}
		return err;
	}

	if(from_env_store){
		*from_env_store = thisenv->env_ipc_from;
	}

	if(perm_store){
		*perm_store = thisenv->env_ipc_perm;
	}
	return thisenv->env_ipc_value;
	// panic("ipc_recv not implemented");
	// return 0;
}

// Send 'val' (and 'pg' with 'perm', if 'pg' is nonnull) to 'toenv'.
// This function keeps trying until it succeeds.
// It should panic() on any error other than -E_IPC_NOT_RECV.
//
// Hint:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int err = 0;
	int try = 0;

	if(!pg){
		pg = (void*)UTOP;
	}

	while(1){
		DEBUG_LOG("\n");
		err = sys_ipc_try_send(to_env,val,pg,perm);
		if(0 == err){
			break;
		}
		if(err != -E_IPC_NOT_RECV){
			panic("%s err[%d]\n",__FUNCTION__,err);
		}
		if(try++ == 1000){
			try = 0;
			sys_yield();
		}
	}

	// panic("ipc_send not implemented");
}

// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
